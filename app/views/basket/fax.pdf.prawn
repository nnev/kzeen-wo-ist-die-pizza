pdf.font_size 11

# LOGO
pdf.image @static[:logo], position: :right, width: 200, at: [pdf.bounds.right-200, pdf.bounds.top]

# ADDRESS
spaced_phone = @static[:phone].gsub(' ', '').scan(/.{1,4}/).join(' ')
time = Time.now.in_time_zone(Rails.application.config.time_zone).strftime("%H:%M Uhr %d.%m.%Y")
adress_table = [
  ['Firma'     , @static[:company]],
  ['Empfänger' , @static[:name]   ],
  [''          , @static[:street] ],
  [''          , @static[:city]   ],
  ['Telefon'   , spaced_phone     ],
  ['E-Mail'    , @static[:email]  ],
  ['Erstellt'  , time             ],
  ['Bemerkung' , @static[:text]   ],
]
pdf.table(adress_table, column_widths: { 0 => 80 }) do
  cells.padding = 1
  cells.borders = []
  columns(0).font_style = :bold
end

# SUM
pdf.move_down 35
pdf.text "Summe: #{€(@basket.sum)}", size: 16, style: :bold

# LOCATION QR CODES
vpos = pdf.cursor + 108

lat = @static[:qr_location][:lat]
lon = @static[:qr_location][:lon]

osm = "http://www.osm.org/?mlat=#{lat}&mlon=#{lon}#map=17/#{lat}/#{lon}"
gmaps = "https://maps.google.de/maps?q=#{lat},#{lon}&num=1&t=m&z=18"

size = 100
right = pdf.bounds.right - 10
pdf.print_qr_code(gmaps, extent: size, stroke: false, pos: [right-size, vpos])
pdf.print_qr_code(osm,   extent: size, stroke: false, pos: [right-size*2-25, vpos])
pdf.text "Open Street Map#{' '*16}Google Maps#{Prawn::Text::NBSP*11}", align: :right

# ORDER TABLE
pdf.move_down 10

orders_table = [[
  "Produkt",
  {content: "Größe"    ,    align: :left},
  {content: "Preis (€)",    align: :right},
  {content: "Beschriftung", align: :right}
]]

newline = "\n#{Prawn::Text::NBSP*4} "
@basket.orders.sorted.each do |order|
  order.order.each do |item|
    prod = ::Remote::Product.new(branch_id: order.branch_id, product_id: item[:product_id])
    size = "#{prod.named_size(item)}"

    plain = ""
    plain << "EXTRAWUNSCH: #{order.comment}\n\n" if order.comment.present?
    plain << prod.name

    if item[:basic_ingred].any?
      prod.named_basic_ingredients(item).each.with_index do |names, idx|
        plain << "#{newline}#{idx+1}. #{names.join(' + ')}"
      end
    end

    if item[:extra_ingred].any?
      prod.named_extra_ingredients(item).each do |name|
        plain << "#{newline}+ #{name}"
      end
    end

    price   = {content: €(prod.price(item)), align: :right}
    nick_id = {content: order.nick_id,       align: :right}
    orders_table << [plain, size, price, nick_id]
  end
end

last = orders_table.size-1
pdf.table(orders_table, column_widths: [280, 100, 65, 90], header: true) do
  cells.padding = 8
  cells.borders = []
  row(0..last).borders = [:top]
  row(0).border_width = 2

  row(last-1).borders = [:top, :bottom]

  row(last).border_width = 2
  row(last).borders = [:bottom]

  row(0).font_style = :bold
end

pdf.number_pages "Seite <page> von <total>", {at: [pdf.bounds.right - 150, 0], width: 150, align: :right }

