defmodule MarsRover do
  @moduledoc """
  Documentation for `MarsRover`.
  """

  @doc """
  Run the application with the given input string,
  returning the transformed output string
  """
  def run(input) do
    %{width: width, height: height, commands: commands} = parse_input(input)
    process_transforms(width, height, commands)
  end

  @doc """
  Parse an input string into a width, height and list of commands
  """
  @spec parse_input(String.t()) :: %{
          commands: list(command()),
          width: integer(),
          height: integer()
        }
  def parse_input(input) do
    [map_size | commands] = String.split(input, "\n")

    [width, height] =
      map_size |> String.split(" ") |> Enum.map(&Integer.parse/1) |> Enum.map(&elem(&1, 0))

    %{commands: Enum.map(commands, &parse_command/1), width: width, height: height}
  end

  @type command :: %{
          x: integer,
          y: integer,
          direction: String.t(),
          movements: list(String.t())
        }

  @doc """
  Parse a command line from the input, consisting of the current state and a list
  of movements
  """
  @spec parse_command(String.t()) :: command()
  def parse_command(command) do
    with "(" <> rest <- command,
         {x, rest} <- Integer.parse(rest),
         ", " <> rest <- rest,
         {y, rest} <- Integer.parse(rest),
         ", " <> rest <- rest,
         {direction, rest} <- String.split_at(rest, 1),
         ") " <> movements <- rest do
      %{x: x, y: y, direction: direction, movements: String.graphemes(movements)}
    end
  end

  @type robot_state :: {integer, integer, String.t(), boolean()}

  @doc """
  Process each of the commands, applying each transform to the initial state,
  returning a formatted string of the new state for each robot
  """
  @spec process_transforms(integer, integer, list(command)) :: String.t()
  def process_transforms(width, height, commands) do
    Enum.map(commands, fn command ->
      Enum.reduce(
        command.movements,
        {command.x, command.y, command.direction, false},
        fn movement, state ->
          case process_transform(movement, state) do
            # If the robot is out of bounds, mark as lost
            {x, y, _, _} when x > width or x < 0 or y > height or y < 0 ->
              put_elem(state, 3, true)

            valid ->
              valid
          end
        end
      )
    end)
    |> Enum.map(fn {x, y, direction, lost?} ->
      "(#{x}, #{y}, #{direction})#{if lost?, do: " LOST", else: ""}"
    end)
    |> Enum.join("\n")
  end

  @doc """
  Apply a movement transformation to a state.
  If the robot is lost, no transform is processed.
  """
  @spec process_transform(String.t(), robot_state) :: robot_state
  def process_transform(_, {x, y, direction, true}), do: {x, y, direction, true}

  def process_transform(movement, {x, y, direction, lost?}) do
    case movement do
      "L" ->
        {x, y, turn("L", direction), lost?}

      "R" ->
        {x, y, turn("R", direction), lost?}

      "F" ->
        case direction do
          "N" -> {x, y + 1, direction, lost?}
          "E" -> {x + 1, y, direction, lost?}
          "S" -> {x, y - 1, direction, lost?}
          "W" -> {x - 1, y, direction, lost?}
        end
    end
  end

  @doc """
  Transform a direction string either left or right
  """
  @spec turn(String.t(), String.t()) :: String.t()
  def turn("L", "N"), do: "W"
  def turn("L", "E"), do: "N"
  def turn("L", "S"), do: "E"
  def turn("L", "W"), do: "S"
  def turn("R", "N"), do: "E"
  def turn("R", "E"), do: "S"
  def turn("R", "S"), do: "W"
  def turn("R", "W"), do: "N"

  @doc """
  Loads a text from from the first CLI argument and prints the input/output
  """
  def run_file do
    input = System.argv() |> List.first() |> File.read!() |> String.trim()

    IO.puts("Input:")
    IO.puts(input)

    IO.puts("\n\nOutput:")
    IO.puts(MarsRover.run(input))
  end
end
