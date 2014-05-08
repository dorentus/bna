class BnaViewController < UIViewController
  CELL_ID = 'BNA_CODE_CELL'
  REGIONS = Bnet::AUTHENTICATOR_HOSTS.keys

  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.whiteColor

    @table = UITableView.alloc.initWithFrame self.view.bounds
    @table.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin   |
                              UIViewAutoresizingFlexibleRightMargin  |
                              UIViewAutoresizingFlexibleTopMargin    |
                              UIViewAutoresizingFlexibleBottomMargin |
                              UIViewAutoresizingFlexibleWidth        |
                              UIViewAutoresizingFlexibleHeight
    @table.separatorStyle = UITableViewCellSeparatorStyleNone
    @table.delegate = self
    @table.dataSource = self
    @table.registerClass(NSClassFromString('AuthenticatorCell'), forCellReuseIdentifier: CELL_ID)

    self.view.addSubview @table

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: :"addAuthenticator:")
  end

  private

  def request_queue
    @request_queue ||= Dispatch::Queue.new 'bna_request'
  end

  def dummy
    # to make sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', ... work
    UIActionSheet.alloc.initWithTitle(nil, delegate:nil, cancelButtonTitle:nil, destructiveButtonTitle:nil, otherButtonTitles:nil)
  end

  def addAuthenticator(sender)
    args = ['Choose Region', self, 'Cancel', nil]
    args.concat REGIONS
    args << nil

    sheet = UIActionSheet.alloc
    sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', *args
    sheet.showFromBarButtonItem(sender, animated: true)
  end

  def actionSheet(sheet, clickedButtonAtIndex: index)
    selected_region = REGIONS.fetch index, nil
    puts "##{index} #{selected_region} choosen" unless selected_region.nil?

    request_queue.async do
      begin
        authenticator = Bnet::Authenticator.request_authenticator(selected_region)
        puts "Authenticator: #{authenticator}"
      rescue Bnet::BadInputError => e
        puts "Error: #{e}"
      rescue Bnet::RequestFailedError => e
        puts "Error: #{e}, #{e.error}"
      end
    end unless selected_region.nil?
  end

  def tableView(tableView, numberOfRowsInSection: section)
    1
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    AuthenticatorCell::DEFAULT_HEIGHT
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(CELL_ID, forIndexPath: indexPath)
  end
end