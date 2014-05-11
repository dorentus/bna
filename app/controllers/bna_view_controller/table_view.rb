module BnaViewControllerTableView
  extend IB

  CELL_ID = 'AUTHENTICATOR_CELL'

  attr_reader :countdown_view

  def tableView(tableView, numberOfRowsInSection: section)
    AuthenticatorList.number_of_authenticators
  end

  def tableView(tableView, cellForRowAtIndexPath: indexPath)
    cell = tableView.dequeueReusableCellWithIdentifier(CELL_ID, forIndexPath: indexPath)
    cell.authenticator = AuthenticatorList.authenticator_at_index(indexPath.row)
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath: indexPath)
    AuthenticatorCell::DEFAULT_HEIGHT
  end

  def tableView(tableView, viewForHeaderInSection: section)
    section_header_view
  end

  def tableView(tableView, heightForHeaderInSection: section)
    2.0 # height of @countdown_view
  end

  def tableView(tableView, commitEditingStyle: editingStyle, forRowAtIndexPath: indexPath)
    return unless editingStyle == UITableViewCellEditingStyleDelete
    cell = tableView.cellForRowAtIndexPath(indexPath)
    if AuthenticatorList.del_authenticator(cell.authenticator)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimationAutomatic)
    end
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
    @countdown_view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin   |
                                       UIViewAutoresizingFlexibleRightMargin  |
                                       UIViewAutoresizingFlexibleTopMargin    |
                                       UIViewAutoresizingFlexibleBottomMargin |
                                       UIViewAutoresizingFlexibleWidth        |
                                       UIViewAutoresizingFlexibleHeight
    @section_header_view = UIView.alloc.initWithFrame(@countdown_view.bounds)
    @section_header_view.addSubview(@countdown_view)
    @section_header_view
  end

  def update_display_link_timer
    return if countdown_view.nil?
    progress = Bnet::Authenticator.get_progress
    countdown_view.progress = progress
    countdown_view.progressTintColor = BnaHelpers.color_at_progress(progress)
  end
end
