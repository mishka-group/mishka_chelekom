defmodule MishkaMob.Device.NotificationPreviewTest do
  @moduledoc """
  Device tests for the Notification Preview page: the app-and-time line, the
  title and the body draw, and the page reaches its props table.
  """
  use MishkaMob.DeviceCase, page: :notification_preview

  test "the preview draws its line, title and body" do
    assert_text("KATI · 19:15")
    assert_text("Dinner in 15 minutes")
    assert_text("KATI · 08:00")
    assert_text("New episode — The Long Hollow")
  end

  test "the page renders both examples and the props table" do
    for heading <- ["A reminder", "A release, on the app's own surface", "Props"] do
      assert_text(heading)
    end
  end
end
