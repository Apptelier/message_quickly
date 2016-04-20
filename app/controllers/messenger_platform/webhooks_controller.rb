module MessengerPlatform
  class WebhooksController < ApplicationController

    def verify
      if params['hub.verify_token'] == '<validation_token>'
        render plain: params['hub.challenge'], status: 200
      else
        render plain: 'Wrong validation token', status: 500
      end
    end

    def callback
      # TODO: how to allow the user to set the callback registry, but pass it to the engine
      # @registry = MessengerPlatform::CallbackRegistry.new
      # @registry.process_request(request.body.read)
      if params[:valid] == true # MessengerPlatform::process_raw(request.body.read)
        render nothing: true, status: 200
      else
        render plain: 'Error processing callback', status: 500
      end
      
    end

  end
end