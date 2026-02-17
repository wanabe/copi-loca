// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Re-initialize Prism.js: Apply highlight after Turbo page transitions
if (window.Prism) {
  document.addEventListener('turbo:load', function() {
    window.Prism.highlightAll();
  });
}

