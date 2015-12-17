class GenerateCommonPrefController < ApplicationController
  require 'sidekiq/api'
  Sidekiq::Queue.new.clear
  Sidekiq::RetrySet.new.clear
  Sidekiq::ScheduledSet.new.clear

  FaceRecognitionJob.perform_later
end
