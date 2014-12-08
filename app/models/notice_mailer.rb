class NoticeMailer < ActionMailer::Base

  def first(sent_at = Time.now)
    @subject    = 'NoticeMailer#first'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end

  def second(sent_at = Time.now)
    @subject    = 'NoticeMailer#second'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end

  def final(sent_at = Time.now)
    @subject    = 'NoticeMailer#final'
    @body       = {}
    @recipients = ''
    @from       = ''
    @sent_on    = sent_at
    @headers    = {}
  end
end
