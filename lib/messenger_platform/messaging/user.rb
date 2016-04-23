module MessengerPlatform
  module Messaging
    class User < Base

      attr_reader :id, :first_name, :last_name, :profile_pic

      def first_name
        @first_name || user_profile.first_name
      end

      def last_name
        @last_name || user_profile.last_name
      end

      private

      def user_profile
        @user_profile ||= MessengerPlatform::Api::UserProfile.find(id)
      end

    end
  end
end
