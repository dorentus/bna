class RestorationViewController < UIViewController
  extend IB

  outlet :error_label, UILabel
  outlet :serial_field, UITextField
  outlet :restorecode_field, UITextField
  ib_action :textChanged

  def viewDidAppear(animated)
    super(animated)
    serial_field.becomeFirstResponder
  end

  def textChanged(sender)
    validate_text_field(sender)
  end

  def textFieldShouldReturn(textField)
    is_valid = validate_text_field(textField)
    if is_valid
      case textField
      when serial_field
        restorecode_field.becomeFirstResponder
      when restorecode_field
        submit
      end
    end
    is_valid
  end

  private

  def restore_queue
    @restore_queue ||= Dispatch::Queue.new 'bna_restore'
  end

  def validate_text_field(text_field)
    puts "checking #{text_field}, #{text_field.text}"
    is_valid = false
    case text_field
    when serial_field
      is_valid = Bnet::Attributes::Serial.is_valid? text_field.text
      error_label.text = is_valid ? nil : 'invalid serial'
      if is_valid && AuthenticatorList.authenticator_exists?(text_field.text)
        error_label.text = 'authenticator already exists'
        is_valid = false
      end
    when restorecode_field
      is_valid =  Bnet::Attributes::Restorecode.is_valid? text_field.text
      error_label.text = is_valid ? nil : 'invalid restoration code'
    end
    is_valid
  end

  def submit
    puts "#{serial_field.text} #{restorecode_field.text}"

    MMProgressHUD.show
    restore_queue.async do
      begin
        authenticator = Bnet::Authenticator.restore_authenticator(serial_field.text, restorecode_field.text)
        puts "Authenticator: #{authenticator}"
        AuthenticatorList.add_authenticator authenticator
        MMProgressHUD.dismissWithSuccess 'success!'
        pc = self.presentingViewController
        self.dismissViewControllerAnimated(
          true,
          completion: lambda { pc.topViewController.reload_and_scroll_to_bottom }
        )
      rescue Bnet::BadInputError => e
        puts "Error: #{e}"
        MMProgressHUD.dismissWithError e.message
      rescue Bnet::RequestFailedError => e
        puts "Error: #{e}"
        MMProgressHUD.dismissWithError e.message
      end
    end

  end
end
