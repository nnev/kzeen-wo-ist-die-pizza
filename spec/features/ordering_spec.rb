require 'rails_helper'

feature 'ordering process', js: true do
  it 'allows me to add an order on desktop' do
    nick = 'capy1'

    # basket page
    visit '/'
    click_on 'New Order'


    # order page
    sleep 5
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
    expect(order.order).to eq [{"product_id"=>184487, "size"=>12956, "extra_ingred"=>[20, 246], "basic_ingred"=>{}}]

    # go back to basket
    sleep 1
    click_on 'Overview'
    expect(page).to have_content 'You still need to pay'

    click_on 'Mark Order As Paid'
    expect(page).to have_content 'You are marked as having paid'
  end
end
