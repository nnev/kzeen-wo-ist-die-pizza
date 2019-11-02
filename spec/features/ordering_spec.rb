require 'rails_helper'

feature 'ordering process', js: true do
  before do
    allow(JsonCache).to receive(:get) do |path|
      full_path = File.join(__dir__, "../fixtures/autogen", path)

      if File.exist?(full_path)
        next JSON.parse(File.read(full_path))
      end

      raise "not stubbed: #{path}\nIf you changed something, you might need to remove this line to allow recording new fixtures. They should be committed to the repo."

      url = Rails.application.config.shop_url + path
      raw = ::Net::HTTP.get(URI.parse(url))
      FileUtils.mkdir_p(File.dirname(full_path))
      File.write(full_path, raw)

      JSON.parse(raw)
    end
  end

  it 'allows me to add an order on desktop' do
    nick = 'capy1'

    # basket page
    visit '/'
    click_on 'New Order'


    # order page
    fill_in('nick', with: nick)
    click_on 'Set Nickname'

    click_on 'Pizza' # left hand menu

    # open add dialog
    row = find('td', text: 'Pizza Margherita').find(:xpath, '..') # TODO: super slow?
    within row do
      click_on '+'
    end

    # make a hipster pizza
    expect(page).to have_content 'Mittel' # wait for load
    choose 'Mittel'; choose 'Mittel' # sometimes doesn't accept on first try?!
    check 'Ananas'
    check 'Feta'
    click_on 'Add To Order'

    # wait for basket to be updated
    expect(page).to have_css('#basket-sum', text: '9,40 €')
    order = Order.find_by(nick: nick)
    expect(order.order).to eq [{product_id: 184487, size: 12956, extra_ingred: [20, 246], basic_ingred: {}}]

    # go back to basket
    sleep 1
    click_on 'Overview'
    expect(page).to have_content 'You still need to pay'

    click_on 'Mark Order As Paid'
    expect(page).to have_content 'You are marked as having paid'
  end
end
