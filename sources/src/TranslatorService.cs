// Marcelo Melo
// 02/04/2024 - Criação inicial

using OpenAI.ChatGpt;
using OpenAI.ChatGpt.Models;
using OpenAI.ChatGpt.Models.ChatCompletion;


namespace CSharpToObjectPascal
{
    internal static class TranslatorService
    {
        private static ChatService AiService = null;
        private static readonly string CreateTextTranslationPrompt = "Quero que você atue como tradutor de en-US para pt-BR. " +
                                                                     "O usuário fornece uma frase e você a traduz. " +
                                                                     "Não traduza o texto delimitado por '<' e '>'." +
                                                                     "Na resposta, escreva APENAS o texto traduzido e o conteudo dentro de '<' e '>'";

        private static string LoadApiKey()
        {
            var key = Environment.GetEnvironmentVariable("OPENAI_API_KEY");
            return key is null ? throw new Exception("A chave de API-OpenAI não foi fornecida.") : key;
        }

        internal static void Start()
        {
            if (Started())
                Stop();

            var config = new ChatGPTConfig
            {
                MaxTokens = 4096,
                Model = "gpt-4-turbo-preview",
                Temperature = ChatCompletionTemperatures.Creative
            };
            AiService = ChatGPT.CreateInMemoryChat(LoadApiKey(), config).Result;
            AiService.GetNextMessageResponse(CreateTextTranslationPrompt).Wait();

        }

        internal static bool Started()
        {
            return AiService is not null;
        }

        internal static void Stop()
        {
            if (!Started())
                return;

            AiService.Stop();
            AiService.Dispose();
            AiService = null;
        }

        internal static string TranslateText(string text)
        {
            if (!Started())
                return text;

            var translatedMsg = AiService.GetNextMessageResponse(text).Result;
            Stop();
            Start();
            return translatedMsg;
        }

    }

}
