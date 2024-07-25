defmodule TestRailMarkdownTest do
  use ExUnit.Case
  doctest TestRailMarkdown

  test "export header" do
    md = """
    # Header 1
    ## Header 2
    ### Header 3
    """

    tr = """
    # Header 1
    ## Header 2
    ### Header 3
    """

    assert TestRailMarkdown.export(md) == tr
  end

  test "export code inline" do
    md = "`Code inline`"
    tr = "`Code inline`"

    assert TestRailMarkdown.export(md) == tr
  end

  test "export code block" do
    md = """
    ```
    The code block

      Preserve indent

        And space
    ```
    """

    tr = """

        The code block
        
          Preserve indent
        
            And space
    """

    assert TestRailMarkdown.export(md) == tr
  end
end
