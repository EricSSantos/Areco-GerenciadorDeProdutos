namespace GerenciadorDeProdutos.Domain.Commons.Settings
{
    public class CorsSettings
    {
        public List<string> DevelopmentOrigins { get; set; } = new();
        public List<string> ProductionOrigins { get; set; } = new();
    }
}
