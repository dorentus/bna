class DetailViewController < UITableViewController
  include TokenDisplay

  def viewDidLoad
    super

    self.title = authenticator.serial
    restorecode_label.text = authenticator.restorecode
    update_token
  end

  def viewWillAppear(animated)
    super(animated)
    start_timer
  end

  def viewDidDisappear(animated)
    super(animated)
    stop_timer
  end
end
