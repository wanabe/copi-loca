// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Re-initialize Prism.js: Apply highlight after Turbo page transitions
if (window.Prism) {
  document.addEventListener('turbo:load', function() {
    // allow function context format in hunk headers, e.g. @@ -1,5 +1,6 @@ functionName
    if (Prism.languages.diff && Array.isArray(Prism.languages.diff.coord)) {
      Prism.languages.diff.coord.forEach((regex, index, arr) => {
        if (regex.source === '^@@.*@@$') {
          arr[index] = /^@@.+?@@.*$/m;
        }
      });
    }
    window.Prism.highlightAll();
  });
}

