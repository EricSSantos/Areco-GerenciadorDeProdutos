using GerenciadorDeProdutos.Domain.Commons.Models.InputModels;
using GerenciadorDeProdutos.Domain.Commons.Models.ViewModels;
using GerenciadorDeProdutos.Domain.Interfaces.Services;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace GerenciadorDeProdutos.API.Controllers.v1
{
    [ApiController]
    [Route("api/v1/products")]
    public class ProductController : ControllerBase
    {
        private readonly IProductService _productService;

        public ProductController(IProductService productService)
        {
            _productService = productService;
        }

        [HttpGet]
        public async Task<ActionResult<ResponseViewModel<IEnumerable<ProductViewModel>>>> GetAll(CancellationToken cancellationToken)
        {
            var result = await _productService.GetAll(cancellationToken);

            return Ok(ResponseViewModel<IEnumerable<ProductViewModel>>.Ok(
                data: result,
                statusCode: HttpStatusCode.OK,
                title: "Produtos recuperados com sucesso."
            ));
        }

        [HttpGet("{id:guid}")]
        public async Task<ActionResult<ResponseViewModel<ProductViewModel>>> GetById(Guid id, CancellationToken cancellationToken)
        {
            var result = await _productService.GetById(id, cancellationToken);

            return Ok(ResponseViewModel<ProductViewModel>.Ok(
                data: result,
                statusCode: HttpStatusCode.OK,
                title: "Produto recuperado com sucesso."
            ));
        }

        [HttpPost]
        public async Task<ActionResult<ResponseViewModel<ProductViewModel>>> Add(
            [FromBody] CreateProductInputModel input,
            CancellationToken cancellationToken)
        {
            var result = await _productService.Add(input, cancellationToken);

            return CreatedAtAction(nameof(GetById), new { id = result.Id }, ResponseViewModel<ProductViewModel>.Ok(
                data: result,
                statusCode: HttpStatusCode.Created,
                title: "Produto criado com sucesso."
            ));
        }

        [HttpPut]
        public async Task<ActionResult<ResponseViewModel<ProductViewModel>>> Update(
            [FromBody] UpdateProductInputModel input,
            CancellationToken cancellationToken)
        {
            var result = await _productService.Update(input, cancellationToken);

            return Ok(ResponseViewModel<ProductViewModel>.Ok(
                data: result,
                statusCode: HttpStatusCode.OK,
                title: "Produto atualizado com sucesso."
            ));
        }

        [HttpDelete("{id:guid}")]
        public async Task<ActionResult<ResponseViewModel<object>>> Delete(Guid id, CancellationToken cancellationToken)
        {
            await _productService.Delete(id, cancellationToken);

            return Ok(ResponseViewModel<object>.Ok(
                data: null,
                statusCode: HttpStatusCode.OK,
                title: "Produto excluído com sucesso."
            ));
        }

        [HttpPost("batch")]
        public async Task<ActionResult<ResponseViewModel<IEnumerable<ProductViewModel>>>> AddBatch(
            [FromBody] IEnumerable<CreateProductInputModel> input,
            CancellationToken cancellationToken)
        {
            var result = await _productService.AddBatch(input, cancellationToken);

            return Ok(ResponseViewModel<IEnumerable<ProductViewModel>>.Ok(
                data: result,
                statusCode: HttpStatusCode.OK,
                title: "Produtos criados com sucesso."
            ));
        }

        [HttpPut("batch")]
        public async Task<ActionResult<ResponseViewModel<IEnumerable<ProductViewModel>>>> UpdateBatch(
            [FromBody] IEnumerable<UpdateProductInputModel> input,
            CancellationToken cancellationToken)
        {
            var result = await _productService.UpdateBatch(input, cancellationToken);

            return Ok(ResponseViewModel<IEnumerable<ProductViewModel>>.Ok(
                data: result,
                statusCode: HttpStatusCode.OK,
                title: "Produtos atualizados com sucesso."
            ));
        }

        [HttpDelete("batch")]
        public async Task<ActionResult<ResponseViewModel<object>>> DeleteBatch(
            [FromBody] IEnumerable<Guid> ids,
            CancellationToken cancellationToken)
        {
            await _productService.DeleteBatch(ids, cancellationToken);

            return Ok(ResponseViewModel<object>.Ok(
                data: null,
                statusCode: HttpStatusCode.OK,
                title: "Produtos excluídos com sucesso."
            ));
        }
    }
}
