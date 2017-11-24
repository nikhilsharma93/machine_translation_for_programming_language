

EOS = "."
GO = "!"
VOCAB = "abcdefghijklmnopqrstuvwxyz .!,+=-*/()1234567890"
VOCABSIZE = #VOCAB
print("vocab size is: ", VOCABSIZE)

local vocab_table = {}
for loop_char = 1,#VOCAB do
    local c = VOCAB:sub(loop_char,loop_char)
    vocab_table[c] = loop_char
end

local reverse_vocab_table = {}
for loop_char = 1,#VOCAB do
    local c = VOCAB:sub(loop_char,loop_char)
    table.insert(reverse_vocab_table, c)
end

function generateSamples(length_max, number)
    local samples = {}
    local targets = {}
    local decoder_in = {}
    for loop_samples = 1,number do
        local length = torch.round(torch.uniform(1,length_max))
        local num1 = torch.round(torch.uniform(10^(length-1), 10^length/2-1))
        local num2 = torch.round(torch.uniform(10^(length-1), 10^length/2-1))
        local target = num1+num2
        local input_string = "print ("..tostring(num1).."+"..tostring(num2)..")"
        local target_string = tostring(target)..EOS
        local decoder_string = GO..tostring(target)
        table.insert(samples, input_string)
        table.insert(targets, target_string)
        table.insert(decoder_in, decoder_string)
    end
    return samples, targets, decoder_in
end

function convertToInts(samples)
    for loop_samples = 1,#samples do
        local s = samples[loop_samples]
        local s_int = torch.Tensor(#s)
        for loop_s = 1,#s do
            s_int[loop_s] = vocab_table[s:sub(loop_s, loop_s)]
        end
        samples[loop_samples] = s_int
    end
    return samples
end

local num_samples = 40000
samples, targets, decoder_in = generateSamples(8,num_samples)
samples = convertToInts(samples)
targets = convertToInts(targets)
decoder_in = convertToInts(decoder_in)


train_data = {
    encoder_in = samples,
    decoder_in = decoder_in,
    size = function() return num_samples end,
    number = num_samples,
    targets = targets,
    reverse_vocab_table = reverse_vocab_table,
    EOS = EOS
}

return {
    train_data = train_data,
    VOCABSIZE = VOCABSIZE,
}
