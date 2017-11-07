package main

// get-branches
type jsonGetBranches struct {
	// Success  bool   `json:"success"`
	// Checksum string `json:"checksum"`
	D struct {
		Branches []struct {
			ID       int    `json:"id"`
			Name     string `json:"name"`
			Street   string `json:"street"`
			StreetNo string `json:"street_no"`
			CityCode string `json:"city_code"`
			City     string `json:"city"`
			Tel      string `json:"tel"`
			// Lati      float64 `json:"lati"`
			// Longi     float64 `json:"longi"`
			// Mbw       int     `json:"mbw"`
			// AreaCodes []struct {
			//  CityCode               string `json:"city_code"`
			//  CityName               string `json:"city_name"`
			//  Mbw                    int    `json:"mbw"`
			//  DeliveryCosts          int    `json:"delivery_costs"`
			//  DeliveryCostsThreshold int    `json:"delivery_costs_threshold"`
			// } `json:"area_codes"`
		} `json:"branches"`
	} `json:"d"`
	// ETitle string `json:"eTitle"`
	// E      string `json:"e"`
}

func (b jsonGetBranches) id() int {
	return b.D.Branches[0].ID
}

// get-categories/1184
type jsonGetCategories struct {
	// Success  bool   `json:"success"`
	// Checksum string `json:"checksum"`
	// BranchID int    `json:"branch_id"`
	D      []jsonCategory `json:"d"`
	ETitle string         `json:"eTitle"`
	E      string         `json:"e"`
}

func (c jsonGetCategories) categories() []jsonCategory {
	return c.D
}

type jsonCategory struct {
	ID          int    `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Discount    int    `json:"discount"`
	DiscountAll int    `json:"discount_all"`
	Mbw         int    `json:"mbw"`
	Picurl      string `json:"picurl"`
	Pos         int    `json:"pos"`
	CountMbw    int    `json:"count_mbw"`
}

type jsonGetProductsOfCategory struct {
	Success  bool          `json:"success"`
	Checksum string        `json:"checksum"`
	BranchID int           `json:"branch_id"`
	Category int           `json:"category"`
	D        []jsonProduct `json:"d"`
	ETitle   string        `json:"eTitle"`
	E        string        `json:"e"`
}

type jsonProduct struct {
	ID                     int     `json:"id"`
	Name                   string  `json:"name"`
	Description            string  `json:"description"`
	No                     string  `json:"no"`
	IsFixed                int     `json:"is_fixed"`
	CountMbw               int     `json:"count_mbw"`
	DiscountEnabled        int     `json:"discount_enabled"`
	DiscountAllEnabled     int     `json:"discount_all_enabled"`
	LowestPrice            float64 `json:"lowest_price"`
	LowestPriceSelfcollect float64 `json:"lowest_price_selfcollect"`
	LowestPriceDelivery    float64 `json:"lowest_price_delivery"`
	PicURL                 string  `json:"pic_url"`
	Sizes                  []int   `json:"sizes"`
}

// https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-products-of-category/1184/20138
// https://delivery-app.app-smart.services/api2.5/D4LQjy8fNbse392x/get-single-product/1184/184470
