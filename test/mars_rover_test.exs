defmodule MarsRoverTest do
  use ExUnit.Case
  doctest MarsRover

  test "produces correct output" do
    input = """
    4 8
    (2, 3, E) LFRFF
    (0, 2, N) FFLFRFF
    """

    expected = """
    (4, 4, E)
    (0, 4, W) LOST
    """

    assert MarsRover.run(input) == output
  end
end
