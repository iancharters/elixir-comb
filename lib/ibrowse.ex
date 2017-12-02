# defmodule MyApp.HttpAsyncResponse do
#   def run(conn, url) do
#     case HTTPotion.get(url, [ibrowse: [stream_to: {self(), :once}]]) do
#       #%HTTPotion.AsyncResponse{id: id} ->
#       #  async_response(conn, id)
#       %HTTPotion.ErrorResponse{message: "retry_later"} ->
#         send_error(conn, "retry_later")
#         Plug.Conn.put_status(conn, 503)
#       %HTTPotion.ErrorResponse{message: msg} ->
#         send_error(conn, msg)
#         Plug.Conn.put_status(conn, 502)
#     end
#   end
#
#   defp async_response(conn, id) do
#     :ok = :ibrowse.stream_next(id)
#
#     receive do
#       {:ibrowse_async_headers, ^id, '200', _headers} ->
#         conn = Plug.Conn.send_chunked(conn, 200)
#         # Here you might want to set proper headers to `conn`
#         # based on `headers` from a response.
#
#         async_response(conn, id)
#       {:ibrowse_async_headers, ^id, status_code, _headers} ->
#         {status_code_int, _} = :string.to_integer(status_code)
#         # If a service responded with an error, we still need to send
#         # this error to a client. Again, you might want to set
#         # proper headers based on response.
#
#         conn = Plug.Conn.send_chunked(conn, status_code_int)
#
#         async_response(conn, id)
#       {:ibrowse_async_response_timeout, ^id} ->
#         Plug.Conn.put_status(conn, 408)
#       {:error, :connection_closed_no_retry} ->
#         Plug.Conn.put_status(conn, 502)
#       {:ibrowse_async_response, ^id, data} ->
#         case Plug.Conn.chunk(conn, chunk) do
#           {:ok, conn} ->
#             async_response(conn, id)
#           {:error, :closed} ->
#             Logger.info "Client closed connection before receiving the last chunk"
#             conn
#           {:error, reason} ->
#             Logger.info "Unexpected error, reason: #{inspect(reason)}"
#             conn
#         end
#       {:ibrowse_async_response_end, ^id} ->
#         conn
#     end
#   end
# end
