package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
)

const (
	configPath = "../config.yaml"
	outputPath = "_temp/index.json"
)

var config Config

func main() {
	if err := readConfig(configPath); err != nil {
		log.Fatal(err)
	}
	recipes, err := readRecipes()
	if err != nil {
		log.Fatal()
	}
}

func readConfig(path string) error {
	b, err := os.ReadFile(path)
	if err != nil {
		return fmt.Errorf("could not open config file %q: %w", path, err)
	}
	if err := json.Unmarshal(b, &config); err != nil {
		return fmt.Errorf("could not unmarshal: %w", err)
	}
	return nil
}

func x(indexFile string) error {

	index, err := os.Create(indexFile)
	if err != nil {
		return fmt.Errorf("could not open index file: %w", err)
	}

}

func readRecipes() ([]Recipe, error) {
	files, err := filepath.Glob("_temp/*.category.txt")
	if err != nil {
		return nil, fmt.Errorf("could not glob: %w", err)
	}

	var recipes []Recipe
	for _, file := range files {
		recipe, err := readRecipe(file)
		if err != nil {
			fmt.Errorf("could not read %q: %w", file, err)
		}
		recipes = append(recipes, recipe)
	}
	return recipes, nil
}

func readRecipe(path string) (Recipe, error) {

}

//go:generate gomodifytags -file main.go -w -struct Config -add-tags json
type Config struct {
	Strings struct {
		UncategorizedLabel string `json:"uncategorized_label"`
	} `json:"strings"`
}

//go:generate gomodifytags -file main.go -w -struct Recipe -add-tags json
type Recipe struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	Category    string `json:"category"`

	Author string `json:"author"`
	Source string `json:"source"`

	Vegan  string `json:"vegan"`  // Refactor to bool
	Veggie string `json:"veggie"` // Refactor to bool

	Htmlfile string `json:"htmlfile"`
}

//go:generate gomodifytags -file main.go -w -struct Category -add-tags json
type Category struct {
	Category            string   `json:"category"`
	CategoryFauxEncoded string   `json:"category_faux_encoded"`
	Recipes             []Recipe `json:"recipes"`
}
