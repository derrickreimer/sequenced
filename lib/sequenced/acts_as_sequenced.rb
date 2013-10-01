require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/class/attribute_accessors'

module Sequenced
	module ActsAsSequenced
		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			# Public: Defines ActiveRecord callbacks to set a sequential ID scoped
			# on a specific class.
			#
			# options - The Hash of options for configuration:
			#           :scope    - The Symbol representing the columm on which the
			#                       sequential ID should be scoped (default: nil)
			#           :column   - The Symbol representing the column that stores the
			#                       sequential ID (default: :sequential_id)
			#           :start_at - The Integer value at which the sequence should
			#                       start (default: 1)
			#           :skip     - Skips the sequential ID generation when the lambda
			#                       expression evaluates to nil. Gets passed the
			#                       model object
			#
			# Examples
			#
			#   class Answer < ActiveRecord::Base
			#     belongs_to :question
			#     acts_as_sequenced :scope => :question_id
			#   end
			#
			# Returns nothing.
			def acts_as_sequenced(options = {})
				# Remove extraneous options
				options.slice!(:scope, :column, :start_at, :skip)

				# Set defaults
				options[:column] ||= :sequential_id
				options[:start_at] ||= 1
				options[:skip] ||= nil

				# Create class accessor for sequenced options
				cattr_accessor :sequenced_options
				self.sequenced_options = options

				# Specify ActiveRecord callback
				before_save :set_sequential_id
				include Sequenced::ActsAsSequenced::InstanceMethods
			end
		end

		module InstanceMethods
			# Internal: Fetches the next sequential ID and assigns it to
			# the sequential ID column if the sequential id is not already
			# defined.
			#
			# Returns nothing.
			# Raises ArgumentError if
			#   1) The specified scope method is undefined,
			#   2) The specified scope method returns nil, or
			#   3) The sequential ID column is undefined.
			def set_sequential_id
				scope = self.class.sequenced_options[:scope]
				column = self.class.sequenced_options[:column]
				skip = self.class.sequenced_options[:skip]

				unless self.respond_to?(column)
					raise ArgumentError, "Column method ##{column.to_s} is undefined"
				end

				# Short-circuit here if the ID is already set
				return unless self.send(column).nil?

				if skip.present?
					return if skip.call(self)
				end

				if scope.present?
					if scope.is_a?(Array)
						scope.each { |s| verify_scope_method(s) }
					else
						verify_scope_method(scope)
					end
				end

				# Fetch the next ID unless it is already defined
				self.send(:"#{column}=", next_sequential_id) until sequential_id_is_unique?
			end

			#Gets all the elements in the same scope of the current record
			#Returns an array object containing all the scoped records arranged in ascending order
			def get_scoped_records
				scope = self.class.sequenced_options[:scope]
				column = self.class.sequenced_options[:column]
				q = self.class.unscoped.where("#{column.to_s} IS NOT NULL").order("#{column.to_s} ASC")

				if scope.is_a?(Symbol)
					q = q.where(scope => self.send(scope))
				elsif scope.is_a?(Array)
					scope.each { |s| q = q.where(s => self.send(s)) }
				end

				return q
			end

			#Promotes up or down a certain scoped record
			#Takes 'up'/:up/'down'/:down for direction parameter
			#Raises Exceptions on failing
			#Returns true on passing
			def promote!(direction)

				column = self.class.sequenced_options[:column]

				seq_min_val=self.get_sequence_top.send(column)
				seq_max_val=self.get_sequence_bottom.send(column)

				q = self.get_scoped_records

				if direction.is_a?(String)
					direction=direction.to_sym
				elsif direction.is_a?(Symbol)
					#do nothing...for now...
				else
					raise ArgumentError, 'Wrong direction.It should only be a string or a symbol'
				end
				if direction==:up
					current_seqid=self.send(column)
					expected_seqid=current_seqid-1
				elsif direction ==:down
					current_seqid=self.send(column)
					expected_seqid=current_seqid+1
				else
					raise ArgumentError, 'Wrong direction.It should only be a string or a symbol with values up/down/:up/:down'
				end
				#If this is a valid sequence ID?
				if expected_seqid<=seq_max_val and expected_seqid>=seq_min_val
					#Lookup the record already occupying that position in the scope
					shuffle_list=q.where({column => expected_seqid})
					if shuffle_list.count>0
						#These should only be one record in the list. If not, there is something wrong. Solution...Sanitize the zequence.
						#It happens iff one manually reassigns a sequence_id without completely handling it or without calling the sanitize op.
						mover=shuffle_list.first

						mover[column]=current_seqid
						self[column]=expected_seqid
						if mover.save and self.save
							#Swap completed successfully. Can return safely
							return true
						else
							raise Exception, 'Something went wrong internally'
						end
					else
						raise Exception, 'mover not found for promotion although one is expected. Sanitize sequence just in case'
					end
				else
					raise Exception, 'Promotion beyond bounding is not allowed. It is suggested to use sanitize_sequence if really needed.'
				end
			end

			# Exception proof promote operation
			#Takes 'up'/:up/'down'/:down for direction parameter
			# Return true or false
			def promote(direction)
				begin
					return self.promote!(direction)
				rescue Exception =>e
					puts "Rescue:#{e.message}"
					return false
				end
			end

			#Same as promote operation, except, this operation swaps the sequential_id of
			#record in position <position> with current record
			def promote_to!(position)
				q=self.get_scoped_records
				min=self.get_sequence_top.sequential_id
				max=self.get_sequence_bottom.sequential_id
				my_sid=self.sequential_id
				if position<=max and position>=min
					replacables=q.where({:sequential_id=>position})
					if replacables.count>0
						replaced=replacables.first
						replaced.sequential_id=my_sid
						if !replaced.save
							raise Exception,"Target replacable entity couldn't be saved"
						end

						self.sequential_id=position
						if !self.save
							raise Exception,"Current entity couldn't be saved"
						else
							return true
						end
					else
						raise Exception,"Replacable record not found in position #{position}"
					end
				else
					raise Exception,"Promotion to an unbound location is a violation."
				end
			end

			def promote_to(position)
				begin
					self.promote_to!(position)
						return true
				rescue Exception=>e
					puts "Rescue:#{e.message}"
					return false
				end
			end

			#Gets the record with the smallest sequential id
			def get_sequence_top
				q=self.get_scoped_records

				return q.first
			end

			#Gets the record with the largest sequential id
			def get_sequence_bottom
				q=self.get_scoped_records

				return q.last
			end

			#Collects all the records of a scope in an order and reassigns sequential_ids in same order
			#starting from start_at value
			def sanitize_sequence
				q=self.get_scoped_records
				column = self.class.sequenced_options[:column]
				if self.class.sequenced_options[:start_at].is_a? Integer
					start_at = self.class.sequenced_options[:start_at]
				else
					start_at=self.class.sequenced_options[:start_at].try(:call, self)
				end

				i= start_at
				q.each do |eachq|
					eachq[column]=i
					if !eachq.save
						raise Exception,"Sanitization failed abruptly"
					end
					i+=1
				end
			end

			# Internal: Verify that the given scope method is defined and does not
			# return nil unexpectedly.
			#
			# scope - A Symbol representing the scope method.
			#
			# Returns nothing.
			# Raises an ArgumentError if
			#   1) The specified scope method is undefined, or
			#   2) The specified scope method returns nil
			def verify_scope_method(scope)
				if !self.respond_to?(scope)
					raise ArgumentError, "Scope method ##{scope.to_s} is undefined"
				elsif self.send(scope).nil?
					raise ArgumentError, "Scope method ##{scope.to_s} returned nil unexpectedly"
				end
			end

			# Internal: Obtain the next sequential ID
			#
			# Returns Integer.
			# Raises ArgumentError if the last sequential ID is not an Integer.
			def next_sequential_id
				scope = self.class.sequenced_options[:scope]
				column = self.class.sequenced_options[:column]

				if self.class.sequenced_options[:start_at].is_a? Integer
					start_at = self.class.sequenced_options[:start_at]
				else
					start_at=self.class.sequenced_options[:start_at].try(:call, self)
				end


				q = self.get_scoped_records

				return start_at unless last_record = q.last
				last_id = last_record.send(column)

				unless last_id.is_a?(Integer)
					raise ArgumentError, "The sequential ID column must contain Integer values"
				end

				last_id + 1 > start_at ? last_id + 1 : start_at
			end

			# Internal: Checks the uniqueness of the sequential ID.
			#
			# Returns Boolean status of uniqueness.
			def sequential_id_is_unique?
				scope = self.class.sequenced_options[:scope]
				column = self.class.sequenced_options[:column]
				return false unless self.send(column).is_a?(Integer)

				q = self.class.unscoped.where(column => self.send(column))

				if scope.is_a?(Symbol)
					q = q.where(scope => self.send(scope))
				elsif scope.is_a?(Array)
					scope.each { |s| q = q.where(s => self.send(s)) }
				end

				q = q.where("NOT id = ?", self.id) if self.persisted?
				q.count > 0 ? false : true
			end
		end
	end
end