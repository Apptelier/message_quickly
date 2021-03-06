require 'json'

require "message_quickly/messaging/base"
require "message_quickly/messaging/attachment"
require "message_quickly/messaging/image_attachment"
require "message_quickly/messaging/video_attachment"
require "message_quickly/messaging/audio_attachment"
require "message_quickly/messaging/template_attachment"
require "message_quickly/messaging/element"
require "message_quickly/messaging/button"
require "message_quickly/messaging/phone_button"
require "message_quickly/messaging/element_share_button"
require "message_quickly/messaging/web_url_button"
require "message_quickly/messaging/postback_button"
require "message_quickly/messaging/account_link_button"
require "message_quickly/messaging/button_template_attachment"
require "message_quickly/messaging/generic_template_attachment"
require "message_quickly/messaging/quick_reply"

require "message_quickly/messaging/receipt/address"
require "message_quickly/messaging/receipt/adjustment"
require "message_quickly/messaging/receipt/element"
require "message_quickly/messaging/receipt/summary"
require "message_quickly/messaging/receipt_template_attachment"

require "message_quickly/messaging/delivery"
require "message_quickly/messaging/message"
require "message_quickly/messaging/entry"
require "message_quickly/messaging/user"
require "message_quickly/messaging/recipient"
require "message_quickly/messaging/sender"

require "message_quickly/messaging/event"
require "message_quickly/messaging/optin_event"
require "message_quickly/messaging/delivery_event"
require "message_quickly/messaging/message_event"
require "message_quickly/messaging/postback_event"
require "message_quickly/messaging/read_event"
require "message_quickly/messaging/account_link_event"
require "message_quickly/change_update_event"

module MessageQuickly
  class CallbackParser

    def initialize(json)
      @json = json
    end

    MESSAGING_WEBHOOK_LOOKUP = {
      optin: MessageQuickly::Messaging::OptinEvent,
      postback: MessageQuickly::Messaging::PostbackEvent,
      delivery: MessageQuickly::Messaging::DeliveryEvent,
      account_linking: MessageQuickly::Messaging::AccountLinkEvent,
      message: MessageQuickly::Messaging::MessageEvent,
      read: MessageQuickly::Messaging::ReadEvent
    }

    def parse
      events = []
      process_entry_json(@json['entry']) do |params|
        if params[:changes].present?
          events << MessageQuickly::ChangeUpdateEvent.new(params)
          next
        end
        MESSAGING_WEBHOOK_LOOKUP.keys.each do |key|
          if params[:messaging].has_key?(key)
            events << MESSAGING_WEBHOOK_LOOKUP[key].new(params[:messaging])
            break
          end
        end
      end
      events.each { |event| yield event if block_given? }
      events
    end

    private

    def process_entry_json(json)
      json.each do |entry_json|
        entry = Messaging::Entry.new(entry_json)
        entry_json['changes']&.each do |event_json|
          yield change_update_callback_params(entry, event_json)
        end
        entry_json['messaging']&.each do |event_json|
          yield messaging_callback_params(entry, event_json)
        end
      end
    end

    def change_update_callback_params(entry, event_json)
      {
        entry: entry,
        changes: event_json.deep_symbolize_keys
      }
    end

    def messaging_callback_params(entry, event_json)
      {
        entry: entry,
        sender: Messaging::Sender.new(event_json['sender']),
        recipient: Messaging::Recipient.new(event_json['recipient']),
        timestamp: event_json['timestamp'],
        messaging: event_json.deep_symbolize_keys
      }
    end

  end
end
