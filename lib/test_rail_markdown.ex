defmodule TestRailMarkdown do
  @moduledoc """
  Documentation for `TestRailMarkdown`.
  """

  @doc """
  Export Markdown `md` into TestRail document format.

  Ref: https://support.testrail.com/hc/en-us/articles/7770931349780-Editor-formatting-reference
  """
  def export(md) when is_binary(md) do
    with {:ok, ast, _} <- Earmark.Parser.as_ast(md) do
      ast
      |> md_ast_to_testrail()
      |> IO.iodata_to_binary()
    else
      error -> raise "parse error #{inspect(error)}" 
    end
  end

  defp md_ast_to_testrail([]), do: []

  defp md_ast_to_testrail([h | t]) do
    case h do
      {"h1", _, [text], _} ->
        [header(1, text) | md_ast_to_testrail(t)]

      {"h2", _, [text], _} ->
        [header(2, text) | md_ast_to_testrail(t)]

      {"h3", _, [text], _} ->
        [header(3, text) | md_ast_to_testrail(t)]

      {"p", _, child, _} ->
        [paragraph(child) | md_ast_to_testrail(t)]

      {"pre", _, child, _} ->
        [preformatted(child) | md_ast_to_testrail(t)]

      {"code", [{"class", "inline"}], [code], _} ->
        [code_inline(code) | md_ast_to_testrail(t)]

      {"code", _, [code], _} ->
        [code_block(code) | md_ast_to_testrail(t)]

      {"a", [{"href", link}], [text], _} ->
        [link(link, text) | md_ast_to_testrail(t)]

      {"table", [], table, _} ->
        [table(table) | md_ast_to_testrail(t)]
    end
  end

  defp header(1, text), do: ["# ", text, ?\n]
  defp header(2, text), do: ["## ", text, ?\n]
  defp header(3, text), do: ["### ", text, ?\n]

  defp paragraph(child) do
    child
    |> md_ast_to_testrail()
    |> Enum.reverse()
  end

  defp preformatted(child) do
    child
    |> md_ast_to_testrail()
    |> Enum.reverse()
  end

  defp code_inline(code), do: [?\`, code, ?\`]

  defp code_block(code) do
    [?\n, "    ", String.replace(code, "\n", "\n    "), ?\n]
  end

  defp link(link, text) do
    [?\[, text, ?\], ?\(, link, ?\)]
  end

  def table([thead | tbody]) do
    [
      ?\n,
      table_head(thead),
      ?\n,
      Enum.map(tbody, &table_body/1)
    ]
  end

  defp table_head({"thead", [], [{"tr", [], columns, _}], _}) do
    ["||| ", Enum.map_intersperse(columns, " | ", &column(&1, true))]
  end

  defp table_body({"tbody", [], rows, _}) do
    fun = fn {"tr", [], columns, _} ->
      ["|| ", Enum.map_intersperse(columns, " | ", &column(&1, false))]
    end

    Enum.map_intersperse(rows, ?\n, fun)
  end

  defp column({_, _, [col], _}, header?) do
    [if(header?, do: ?:, else: []), col]
  end
end
