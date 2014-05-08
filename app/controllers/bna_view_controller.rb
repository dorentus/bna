module AuthenticatorTable
  CELL_ID = 'AUTHENTICATOR_CELL'

  def tableView(tableView, numberOfRowsInSection: section)
    1
  end

  def numberOfSectionsInTableView(tableView)
    15
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    tableView.dequeueReusableCellWithIdentifier(CELL_ID, forIndexPath: indexPath)
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    AuthenticatorCell::DEFAULT_HEIGHT
  end

  def tableView(tableView, heightForHeaderInSection: section)
    0
  end

  def tableView(tableView, heightForFooterInSection: section)
    0
  end
end

module AddButton
  REGIONS = Bnet::AUTHENTICATOR_HOSTS.keys

  def request_queue
    @request_queue ||= Dispatch::Queue.new 'bna_request'
  end

  def dummy
    # to make sheet.send :'initWithTitle:delegate:cancelButtonTitle:destructiveButtonTitle:otherButtonTitles:', ... work
    UIActionSheet.alloc.initWithTitle(nil, delegate:nil, cancelButtonTitle:nil, destructiveButtonTitle:nil, otherButtonTitles:nil)
  end

  def addButtonTapped(sender)
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
end

class BnaViewController < UITableViewController
  extend IB

  include AuthenticatorTable
  include AddButton

  ib_action :addButtonTapped

  def viewDidLoad
    super
  end

end
