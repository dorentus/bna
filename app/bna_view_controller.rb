class BnaViewController < UIViewController
  CODE_CELL_ID = 'BNA_CODE'

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

  def addAuthenticator(sender)
    sheet = UIActionSheet.alloc.initWithTitle('Choose Region',
                                              delegate: self,
                                              cancelButtonTitle: 'Cancel',
                                              destructiveButtonTitle: nil,
                                              otherButtonTitles: 'CN', 'US', 'EU', nil)
    sheet.showFromBarButtonItem(sender, animated: true)
  end

  def actionSheet(sheet, clickedButtonAtIndex: index)
    puts "##{index} choosen"
  end

  def tableView(tableView, numberOfRowsInSection: section)
    5
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(CODE_CELL_ID, forIndexPath: indexPath)
  end
end
