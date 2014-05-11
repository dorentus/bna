module BnaViewControllerAddButton
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
        AuthenticatorList.add_authenticator authenticator
        Dispatch::Queue.main.sync do
          self.tableView.reloadData
        end
      rescue Bnet::BadInputError => e
        puts "Error: #{e}"
      rescue Bnet::RequestFailedError => e
        puts "Error: #{e}, #{e.error}"
      end
    end unless selected_region.nil?
  end
end
