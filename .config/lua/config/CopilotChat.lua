-- https://github.com/CopilotC-Nvim/CopilotChat.nvim

local status, copilotc = pcall(require, 'CopilotChat')
if (not status) then return end

local select = require('CopilotChat.select')
--
copilotc.setup {
  show_help = 'yes',
  prompts = {
    Explain = {
      prompt = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text. Please translate the answer into Japanese.',
      mapping = '<leader>ce',
    },
    Review = {
      prompt = '/COPILOT_REVIEW Review the selected code. Please translate the answer into Japanese.',
      callback = function(response, source)
        -- see config.lua for implementation
      end,
    },
    Fix = {
      prompt = '/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed. Please translate the answer into Janapnese.',
      mapping = '<leader>cf',
    },
    Optimize = {
      prompt = '/COPILOT_GENERATE Optimize the selected code to improve performance and readablilty. Please translate the answer into Japanese.',
      mapping = '<leader>co',
    },
    Docs = {
      prompt = '/COPILOT_GENERATE Please add documentation comment for the selection. Please translate the answer into Japanese.',
      mapping = '<leader>cd',
    },
    Tests = {
      prompt = '/COPILOT_GENERATE Please generate tests for my code. Please translate the answer into Japanese.',
      mapping = '<leader>ct',
    },
    FixDiagnostic = {
      prompt = 'Please assist with the following diagnostic issue in file. Please translate the answer into Japanese.',
      mapping = '<leader>cx',
      selection = select.diagnostics,
    },
    Commit = {
      prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
      mapping = '<leader>cc',
      selection = select.gitdiff,
    },
    CommitStaged = {
      prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
      mmaping = '<leader>cs',
      selection = function(source)
        return select.gitdiff(source, true)
      end,
    },
  },
}
