function gerarResumo(nomeCliente, totalCompra) {
    // Assume que formatarMoedaBRL está disponível
    const valorFormatado = formatarMoedaBRL(totalCompra);
    return `Cliente: ${nomeCliente}, Total a Pagar: ${valorFormatado}`;
}