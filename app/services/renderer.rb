class Renderer < AbstractController::Base
  include AbstractController::Rendering
  include AbstractController::Layouts
  include AbstractController::Helpers
  include AbstractController::Translation
  include AbstractController::AssetPaths

  helper ApplicationHelper
  self.view_paths = 'app/views'

  def render(partial, locals={})
    render_to_string partial: partial, layout: false, locals: locals
  end
end
