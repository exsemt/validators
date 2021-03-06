module ActiveModel
  module Validations
    class SshPrivateKeyValidator < EachValidator
      def validate_each(record, attribute, value)
        return if value.blank? && options[:allow_blank]
        return if value.nil? && options[:allow_nil]

        sshkey = SSHKey.new(value.to_s)
        validate_type(record, attribute, sshkey)
        validate_bits(record, attribute, sshkey)
      rescue OpenSSL::PKey::DSAError, OpenSSL::PKey::RSAError
        record.errors.add(
          attribute,
          :invalid_ssh_private_key,
          message: options[:message],
          value: value
        )
      end

      private

      def validate_type(record, attribute, sshkey)
        return unless options[:type]

        valid = [options[:type]].flatten.compact.map(&:to_s).include?(sshkey.type)

        return if valid

        record.errors.add(
          attribute,
          :invalid_ssh_private_key_type,
          message: options[:message],
          value: (%w[rsa dsa] - [sshkey.type])[0].upcase
        )
      end

      def validate_bits(record, attribute, sshkey)
        return unless options[:bits]
        return if sshkey.bits >= options[:bits].to_i

        record.errors.add(
          attribute,
          :invalid_ssh_private_key_bits,
          message: options[:message],
          value: sshkey.bits,
          required: options[:bits]
        )
      end
    end

    module ClassMethods
      # Validates whether or not the specified CNPJ is valid.
      #
      #   class User < ActiveRecord::Base
      #     validates_ssh_private_key :key
      #   end
      #
      def validates_ssh_private_key(*attr_names)
        require "sshkey"
        validates_with SshPrivateKeyValidator, _merge_attributes(attr_names)
      rescue LoadError
        fail "sshkey is not part of the bundle. Add it to Gemfile."
      end
    end
  end
end
