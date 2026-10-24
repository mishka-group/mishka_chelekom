# Device tests drive a real app on a phone; `mix test --only device` opts in.
# Everything else, `mix precommit` included, runs without one.
ExUnit.start(exclude: [:device])

# The device suite's one health number: a tap that had to be repeated means the
# pacing in MishkaMob.Device has a hole. Silent unless the device suite ran.
ExUnit.after_suite(fn _result ->
  case MishkaMob.Device.stats() do
    %{taps: 0} ->
      :ok

    %{taps: taps, retried: retried} ->
      IO.puts("\ndevice taps: #{taps} delivered, #{retried} dropped and repeated")
  end
end)
