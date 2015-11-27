class GenerateCommonPrefController < ApplicationController

  FaceRecognitionJob.perform_later
  ApplyPrefJob.set(wait:35.seconds).perform_later
end
