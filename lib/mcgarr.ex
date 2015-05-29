defmodule McGarr do
  @doc ~S"""
  Load the file into a bitstring.

  ## Example

      iex> string = McGarr.load
      iex> String.starts_with?(string, "A->B")
      true

  """
  def load do
    filename = "#{__DIR__}/../test/graph.txt"
    {:ok, string} = File.read(filename)
    string
  end

  @doc ~S"""
  Parses the text into dependency pairs.

  ## Examples

      iex> McGarr.parse "A->B\r\nB->C\r\nC->Z\r\n"
      [["A","B"],["B","C"],["C","Z"]]

  """
  def parse(string) do
    Enum.map(String.split(string), fn(x) -> String.split(x, "->") end)
  end

  @doc ~S"""
  Find pairs that start with the same letter.

  ## Examples

      iex> McGarr.fetch_children "B", [["A","B"],["B","C"],["B","D"],["C","Z"]]
      [["B","C"],["B","D"]]

  """
  def fetch_children(parent, list) do
    Enum.filter(list, fn(x) -> parent == hd(x) end)
  end

  @doc ~S"""
  Recurse through the list and flatten the dependency relationships into a tree structure.

  ## Examples

      iex> McGarr.flatten [["A","B"],["B","C"],["B","D"],["C","Z"]]
      ["A","AB","ABC","ABCZ","ABD"]

      iex> McGarr.flatten [["A","B"],["B","E"],["B","C"],["B","D"],["C","Z"],["B","F"],["B","Z"],["Z","Y"]]
      ["A","AB","ABE","ABC","ABCZ","ABCZY","ABD","ABF","ABZ","ABZY"]

      # Ignore circular dependency
      #iex> McGarr.flatten [["A","B"],["B","A"],["B","E"],["B","C"],["B","D"],["C","Z"],["B","F"],["B","Z"],["Z","Y"]]
      #["A","AB","ABE","ABC","ABCZ","ABCZY","ABD","ABF","ABZ","ABZY"]

  """
  def flatten(list) do
    root = hd(hd(list))
    flatten(fetch_children(root, list), list, [root], "")
  end
  def flatten([], _list, ac, _prefix) do
    ac
  end
  def flatten([h|l], list, ac, prefix) do
    child = hd(tl(h))
    # This following condition stops cyclical dependencies.
    case String.contains?(prefix, child) do
      true -> flatten(l, list, ac, prefix)
      _    -> 
        parent = hd(h)
        children = fetch_children(child, list)
        # Looks tricky, but really we're just recursively adding the children into the string.
        flatten(l, list, ac ++ ["#{prefix}#{h}"] ++ flatten(children, list, [], "#{prefix}#{parent}"), prefix)
    end
  end

  @doc ~S"""
  Convert the flat tree into the ASCII representation.

  ## Examples

      iex> McGarr.asciify ["A","AB","ABC","ABCZ","ABD"]
      "A\r\n\\_ B\r\n   |_ C\r\n   |  \\_ Z\r\n   \\_ D"

  """
  def asciify(list) do
    [root|l] = list
    map_of_words = [root] ++ Enum.map(l, fn(x) -> asciify_word(x, list) end)
    Enum.join(map_of_words, "\r\n")
  end

############## Approximately the 4-hour mark, working distractedly at a conference. ###################

  @doc ~S"""
  Given a list of the flattened strings, find the elements with the same prefix and see if this
  is the last of those elements.  This is a helper function that will be needed for the next part.

  ## Examples

      iex> list = ["ABCEHLIO","ABCEHLIOP","ABCEHLIOPQ","ABCEHLIP","ABCEHLIPQ","ABCEHLIK","ABCEHLIKN"]
      iex> McGarr.last_child("ABCEHLIO", list)
      false
      iex> McGarr.last_child("ABCEHLIP", list)
      false
      iex> McGarr.last_child("ABCEHLIK", list)
      true

  """
  def last_child(word, list) do
    prefix   = String.slice(word, 0..-2)
    siblings = Enum.filter(list, fn(x) -> String.starts_with?(x, prefix) end)
    case Enum.reverse(siblings) do
      [last_child|_] -> String.starts_with?(last_child, word)
      _ -> false
    end
  end

  @doc ~S"""
  For a given word, print the ASCII version as one line.

  ## Examples

      iex> list = ["ABCEHLIO","ABCEHLIOP","ABCEHLIOPQ","ABCEHLIP","ABCEHLIPQ","ABCEHLIK","ABCEHLIKN"]
      iex> McGarr.asciify_word("ABCEHLIO", list)
      "                  |_ O"
      iex> McGarr.asciify_word("ABCEHLIPQ", list)
      "                  |  \\_ Q"
      iex> McGarr.asciify_word("ABCEHLIKN", list)
      "                     \\_ N"

  """
  def asciify_word(word, list) do
    asciify_word(word, list, 1, String.length(word), "")
  end
  def asciify_word(word, list, char, length, ac) when char + 1 == length do
    space = case last_child(word, list) do
      true -> "\\_ "
      _    -> "|_ "
    end
    "#{ac}#{space}#{String.at(word, char)}"
  end
  def asciify_word(word, list, char, length, ac) do
    prefix = String.slice(word, 0, char + 1)
    space  = case last_child(prefix, list) do
      true -> "   "
      _    -> "|  "
    end
    asciify_word(word, list, char + 1, length, "#{ac}#{space}")
  end

  @doc ~S"""
  Tie it all together, like a nice rug would tie together my living room.
  """
  def homework do
    file = McGarr.load
    data = McGarr.parse(file)
    tree = McGarr.flatten(data)
    IO.puts McGarr.asciify(tree)
  end
end
