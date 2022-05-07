defmodule MarsRoverTest do
  use ExUnit.Case
  doctest MarsRover

  test "produces correct output" do
    input =
      """
      4 8
      (2, 3, E) LFRFF
      (0, 2, N) FFLFRFF
      """
      |> String.trim()

    expected =
      """
      (4, 4, E)
      (0, 4, W) LOST
      """
      |> String.trim()

    assert MarsRover.run(input) == expected
  end

  test "produces correct output (example 2)" do
    input =
      """
      4 8
      (2, 3, N) FLLFR
      (1, 0, S) FFRLF
      """
      |> String.trim()

    expected =
      """
      (2, 3, W)
      (1, 0, S) LOST
      """
      |> String.trim()

    assert MarsRover.run(input) == expected
  end

  test "processes transform" do
    assert MarsRover.process_transform("L", {0, 0, "N", false}) == {0, 0, "W", false}
    assert MarsRover.process_transform("F", {2, 3, "E", false}) == {3, 3, "E", false}
  end

  test "parses input" do
    input =
      """
      4 8
      (2, 3, N) FLLFR
      (1, 0, S) FFRLF
      """
      |> String.trim()

    assert MarsRover.parse_input(input) == %{
             commands: [
               %{
                 direction: "N",
                 movements: ["F", "L", "L", "F", "R"],
                 x: 2,
                 y: 3
               },
               %{
                 direction: "S",
                 movements: ["F", "F", "R", "L", "F"],
                 x: 1,
                 y: 0
               }
             ],
             height: 8,
             width: 4
           }
  end
end
