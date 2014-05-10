module BnaViewControllerTableView
  extend IB

  CELL_ID = 'AUTHENTICATOR_CELL'

  attr_reader :countdown_view

  def tableView(tableView, numberOfRowsInSection: section)
    2
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
