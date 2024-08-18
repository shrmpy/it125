package main

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"log"
	"math/rand/v2"
	"os"

	"github.com/go-echarts/go-echarts/v2/charts"
	"github.com/go-echarts/go-echarts/v2/opts"
	_ "github.com/go-sql-driver/mysql"
	"github.com/shrmpy/it125/data"
)

func main() {
	uri := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASS"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_DATABASE"))
	db, err := sql.Open("mysql", uri)
	if err != nil {
		panic(err)
	}
	defer db.Close()
	generateOrdersData(db)
	printCashiers(db)
	printSellers(db)
}
func printCashiers(db *sql.DB) {
	cash := cashiersData(db)

	pie := pieBase("sales by cashier", cash)

	f, err := os.Create("cashiers.html")
	if err != nil {
		panic(err)
	}
	pie.Render(io.MultiWriter(f))
}
func printSellers(db *sql.DB) {
	sell := sellersData(db)

	pie := pieBase("sales by menuitem", sell)

	f, err := os.Create("sellers.html")
	if err != nil {
		panic(err)
	}
	pie.Render(io.MultiWriter(f))
}

func pieBase(title string, data []opts.PieData) *charts.Pie {
	pie := charts.NewPie()
	pie.SetGlobalOptions(
		charts.WithTitleOpts(opts.Title{Title: title}),
	)

	pie.AddSeries("pie", data).
		SetSeriesOptions(charts.WithLabelOpts(
			opts.Label{
				Show:      opts.Bool(true),
				Formatter: "{b}: {c}",
			}),
		)

	return pie
}

// random data for orders
func generateOrdersData(db *sql.DB) {
	ctx := context.Background()
	// prepare sp call
	stmt := "CALL insert_orderitem(?, ?, ?, ?, ?, ?, ?);"

	// create 100 random order items
	for i := 0; i < 100; i++ {

		_, err := db.ExecContext(ctx, stmt,
			sql.Null[int]{Valid: false},
			randN(5),
			randN(5),
			randN(5),
			randN(2),
			randN(8),
			randN(5))
		if err != nil {
			log.Printf("Random data fail, %s", err)
			return
		}
	}
}

// sales by cashiers
func cashiersData(db *sql.DB) []opts.PieData {
	ctx := context.Background()
	q := data.New(db)

	list, err := q.ListCashiers(ctx)
	if err != nil {
		log.Fatalf("Fetch cashiers fail, %s", err)
	}

	items := make([]opts.PieData, 0)
	for _, sales := range list {
		items = append(items,
			opts.PieData{
				Name:  sales.CashierName.String,
				Value: sales.ItemsCount,
			})
	}

	return items
}

// popular menu item
func sellersData(db *sql.DB) []opts.PieData {
	ctx := context.Background()
	q := data.New(db)

	list, err := q.SellerItem(ctx)
	if err != nil {
		log.Fatalf("Fetch menu items fail, %s", err)
	}

	items := make([]opts.PieData, 0)
	for _, sales := range list {
		items = append(items,
			opts.PieData{
				Name:  sales.MenuItem,
				Value: sales.ItemsCount,
			})
	}

	return items
}

// random that is non-zero
func randN(n int) int {
	x := rand.IntN(n)
	if x == 0 {
		return n
	}
	return x
}
