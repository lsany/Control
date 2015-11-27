class FaceRecognitionJob < ActiveJob::Base
  queue_as :default
  after_perform :make_another_request
  def perform
    $i = 0
    while $i < 1  do
      system '/home/NEC/NeoFace/Video_Verify_Final/ScoreCheck'
      $i +=1
    end
  end

  private
  def make_another_request
    FaceRecognitionJob.set(wait: 30.seconds).perform_later
  end
end
