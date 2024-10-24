defmodule StreamingPi do
  def stream do
    Stream.unfold({1, 0, 1, 1, 3, 3}, &next_digit/1)
  end

  defp next_digit({q, r, t, k, n, l}) when 4 * q + r - t < n * t do
    {n, {q * 10, 10 * (r - n * t), t, k, div(10 * (3 * q + r), t) - 10 * n, l}}
  end

  defp next_digit({q, r, t, k, _n, l}) do
    next_digit({q * k, (2 * q + r) * l, t * l, k + 1, div(q * 7 * k + 2 + r * l, t * l), l + 2})
  end
end
