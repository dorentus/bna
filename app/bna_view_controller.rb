class BnaViewController < UIViewController
  CODE_CELL_ID = 'BNA_CODE_CELL'
  Regions = [:CN, :US, :EU]

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
    @table.delegate = self
    @table.dataSource = self
    @table.registerClass(NSClassFromString('UITableViewCell'), forCellReuseIdentifier: CODE_CELL_ID)

    self.view.addSubview @table

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemAdd, target: self, action: :"addAuthenticator:")
  end

  private

  def dummy
    # to make sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', ... work
    UIActionSheet.alloc.initWithTitle(nil, delegate:nil, cancelButtonTitle:nil, destructiveButtonTitle:nil, otherButtonTitles:nil)
  end

  def addAuthenticator(sender)
    args = ['Choose Region', self, 'Cancel', nil]
    args.concat Regions
    args << nil

    sheet = UIActionSheet.alloc
    sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', *args
    sheet.showFromBarButtonItem(sender, animated: true)
  end

  def actionSheet(sheet, clickedButtonAtIndex: index)
    selected_region = Regions.fetch index, nil
    puts "##{index} #{selected_region} choosen" unless selected_region.nil?
  end

  def tableView(tableView, numberOfRowsInSection: section)
    0
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(CODE_CELL_ID, forIndexPath: indexPath)
  end
end
