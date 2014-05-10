module AuthenticatorTable
  extend IB

  CELL_ID = 'AUTHENTICATOR_CELL'

  attr_reader :countdown_view

  def tableView(tableView, numberOfRowsInSection: section)
    15
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELL_ID, forIndexPath: indexPath)
    if indexPath.row == 1
      cell.authenticator = Bnet::Authenticator.new 'CN-1402-1943-1283', '4202aa2182640745d8a807e0fe7e34b30c1edb23'
    else
      cell.authenticator = Bnet::Authenticator.new "EU-1405-0910-1768", "f498eb5fa8501cf9fa752455ec799c498117afab"
    end
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    AuthenticatorCell::DEFAULT_HEIGHT
  end

  def tableView(tableView, viewForHeaderInSection: section)
    section_header_view
  end

  def tableView(tableView, heightForHeaderInSection: section)
    2
  end

  def tableView(tableView, didSelectRowAtIndexPath: indexPath)
    cell = tableView.cellForRowAtIndexPath indexPath
    tableView.deselectRowAtIndexPath(indexPath, animated: true) if cell.selected?
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    # This method doesn’t have to do anything.
    # Once implemented, you’ll be able to side swipe on a cell and the delete button will appear.
    # WTF...
  end

  def scrollViewDidScroll(scrollView)
    return if countdown_view.nil?
    y_offset =  scrollView.contentOffset.y + scrollView.contentInset.top
    if y_offset < 0
      countdown_view.transform = CGAffineTransformMakeTranslation(0, y_offset)
    else
      countdown_view.transform = CGAffineTransformIdentity
    end
  end

  def section_header_view
    return @section_header_view unless @section_header_view.nil?
    @countdown_view = UIProgressView.alloc.initWithProgressViewStyle(UIProgressViewStyleDefault)
    @countdown_view.trackTintColor = UIColor.clearColor
    @countdown_view.progress = 0.5
    @section_header_view = UIView.alloc.initWithFrame(CGRectMake(0, 0, 320, 2))
    @section_header_view.addSubview(@countdown_view)
    @section_header_view
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
