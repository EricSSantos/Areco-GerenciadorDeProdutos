using System.Net;

namespace GerenciadorDeProdutos.Domain.Commons.Models.ViewModels
{
    public class ResponseViewModel<T>
    {
        public HttpStatusCode StatusCode { get; init; }
        public string Title { get; init; } = string.Empty;
        public T? Data { get; init; }
        public IReadOnlyList<string> Errors { get; init; } = Array.Empty<string>();

        protected ResponseViewModel() { }

        public static ResponseViewModel<T> Ok(
            T data,
            HttpStatusCode statusCode = HttpStatusCode.OK,
            string title = "Operação realizada com sucesso.") =>
            new()
            {
                StatusCode = statusCode,
                Title = title,
                Data = data,
                Errors = Array.Empty<string>()
            };

        public static ResponseViewModel<T> Error(
            IEnumerable<string> errors,
            HttpStatusCode statusCode = HttpStatusCode.BadRequest,
            string title = "Falha ao realizar a operação.") =>
            new()
            {
                StatusCode = statusCode,
                Title = title,
                Data = default,
                Errors = errors != null
                         ? new List<string>(errors)
                         : Array.Empty<string>()
            };
    }
}
