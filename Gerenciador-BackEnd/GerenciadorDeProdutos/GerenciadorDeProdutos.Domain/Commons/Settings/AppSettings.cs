namespace GerenciadorDeProdutos.Domain.Commons.Settings
{
    public class AppSettings
    {
        public Dictionary<string, AppVersion> Versions { get; set; } = new();

        public class AppVersion
        {
            public string Name { get; set; } = null!;
            public string Description { get; set; } = null!;
        }
    }
}
