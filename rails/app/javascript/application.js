// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Prism.js再初期化: Turboページ遷移後にもハイライトを適用
if (window.Prism) {
  document.addEventListener('turbo:load', function() {
    window.Prism.highlightAll();
  });
}

