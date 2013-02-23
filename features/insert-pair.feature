Feature: Autoinsert pairs
  In order to type less
  As a user
  I want to insert pairs automatically

  Scenario: Insert singlechar pairs using default setting
    Given I turn on smartparens
    When I type "("
    Then I should see "()"
    When I type "`"
    Then I should see "`'"
    
  Scenario: Insert singlechar pairs in special modes
    Given I turn on rst-mode
    And I turn on smartparens
    When I type "`"
    Then I should see "``"
    Given I turn on latex-mode
    And I turn on smartparens
    And I type "$"
    Then I should see "$$"

  Scenario: Insert multichar pairs using default settings
    Given I turn on smartparens
    When I type "\{"
    Then I should see "\{\}"
    When I type "\\("
    Then I should see "\\(\\)"

  Scenario: Insert multichar pairs in special modes
    Given I turn on latex-mode
    And I turn on smartparens
    When I type "\["
    Then I should see "\[\]"

  Scenario: Insert a pair and skip closing
    Given I turn on smartparens
    When I type "("
    And I type "abc"
    And I type ")"
    Then I should see "(abc)"
    And the cursor should be at point "6"

  Scenario: Insert a pair and skip closing
    Given I turn on smartparens
    When I type "\{"
    And I type "abc"
    And I type "\}"
    Then I should see "\{abc\}"
    And the cursor should be at point "8"

  Scenario: Test sp-autoinsert-if-followed-by-same 0
    Given I set sp-autoinsert-if-followed-by-same to 0
    And I turn on smartparens
    And I type "("
    Then I should see "()"
    When I press "C-b" 
    And I type "("
    Then I should see "()()"

  Scenario: Test sp-autoinsert-if-followed-by-same 1
    Given I set sp-autoinsert-if-followed-by-same to 1
    And I turn on smartparens
    And I type "("
    Then I should see "()"
    When I press "C-b" 
    And I type "("
    Then I should see "(()"
    When I set sp-autoescape-string-quote to nil
    And I clear the buffer
    And I type "\"\""
    Then I should see "\"\""

  Scenario: Test sp-autoinsert-if-followed-by-same 2
    Given I set sp-autoinsert-if-followed-by-same to 2
    And I set sp-autoescape-string-quote to nil
    And I turn on latex-mode
    And I turn on smartparens
    And I type "$$"
    Then I should see "$$$$"
    When I clear the buffer
    And I type "("
    And I press "C-b"
    And I type "("
    Then I should see "(()"

  Scenario: Test sp-autoinsert-if-followed-by-word t
    Given I set sp-autoinsert-if-followed-by-word to t
    And I turn on smartparens
    And I insert "word"
    And I press "C-a"
    And I type "("
    Then I should see "()word"
    And the cursor should be at point "2"
    When I clear the buffer
    And I insert "word"
    And I press "C-a"
    And I type "\("
    Then I should see "\(\)word"
    And the cursor should be at point "3"

  Scenario: Test sp-autoinsert-if-followed-by-word nil
    Given I set sp-autoinsert-if-followed-by-word to nil
    And I turn on smartparens
    And I insert "word"
    And I press "C-a"
    And I type "("
    Then I should see "(word"
    And the cursor should be at point "2"
    When I clear the buffer
    And I insert "word"
    And I press "C-a"
    And I type "\("
    Then I should see "\(word"
    And the cursor should be at point "3"

  Scenario: Test sp-autoinsert-quote-if-followed-by-closing-pair t
    Given I set sp-autoinsert-quote-if-followed-by-closing-pair to t
    And I turn on smartparens
    And I type "["
    And I insert "one or two words"
    And I press "C-5 C-b"
    And I insert "\""
    And I press "C-5 C-f"
    And I type "\""
    Then I should see "[one or two \"words\"\"]"
    When I press "<backspace>"
    And I type " "
    And I press "C-b"
    And I type "\""
    Then I should see "[one or two \"words\"\" ]"

  Scenario: Test sp-autoinsert-quote-if-followed-by-closing-pair nil
    Given I set sp-autoinsert-quote-if-followed-by-closing-pair to nil
    And I turn on smartparens
    And I type "["
    And I insert "one or two words"
    And I press "C-5 C-b"
    And I insert "\""
    And I press "C-5 C-f"
    And I type "\""
    Then I should see "[one or two \"words\"]"
    When I press "<backspace>"
    And I type " "
    And I press "C-b"
    And I type "\""
    Then I should see "[one or two \"words\"\" ]"

  Scenario: Add local pair
    Given I add a local pair "'/!" on "rst-mode"
    And I turn on rst-mode
    And I turn on smartparens
    When I press "'"
    Then I should see "'!"
    Given I switch to buffer "*new*"
    And I turn on text-mode
    And I turn on smartparens
    When I press "'"
    Then I should see "''"

  Scenario: Filter to insert only in strings
    Given I turn on emacs-lisp-mode
    And I turn on smartparens
    And I type "`"
    Then I should not see "`'"
    When I clear the buffer
    And I insert ""hello world""
    And I go to word "world"
    And I press "SPC C-b"
    And I type "`"
    Then I should see ""hello `' world""
    Given I add a local pair "[/]" on "emacs-lisp-mode" enabled only in string
    And I clear the buffer
    And I type "["
    Then I should not see "[]"
    When I insert ""some text""
    And I go to word "text"
    And I press "SPC C-b"
    And I type "["
    Then I should see "[]"

  Scenario: Filter to insert only in code
    Given I add a local pair "(/)" on "emacs-lisp-mode" enabled only in code
    And I turn on emacs-lisp-mode
    And I turn on smartparens
    And I type "("
    Then I should see "()"
    When I clear the buffer
    And I insert ""hello world""
    And I go to word "world"
    And I press "SPC C-b"
    And I type "("
    Then I should not see "()"
    Given I add a local pair "\{/\}" on "python-mode" enabled only in code
    And I clear the buffer
    And I turn on python-mode
    And I turn on smartparens
    And I type "\{"
    Then I should see "\{\}"
    When I clear the buffer
    And I insert "'some text'"
    And I go to word "text"
    And I press "SPC C-b"
    And I type "\{"
    Then I should not see "\{\}"

  Scenario: Filter to insert only when not in code
    Given I add a local pair "[/]" on "emacs-lisp-mode" disabled only in code
    And I turn on emacs-lisp-mode
    And I turn on smartparens
    And I clear the buffer
    And I type "["
    Then I should not see "[]"
    When I insert ""some text""
    And I go to word "text"
    And I press "SPC C-b"
    And I type "["
    Then I should see "[]"

  Scenario: Filter to insert only when not in string
    Given I add a local pair "(/)" on "emacs-lisp-mode" disabled only in string
    And I turn on emacs-lisp-mode
    And I turn on smartparens
    And I type "("
    Then I should see "()"
    When I clear the buffer
    And I insert ""hello world""
    And I go to word "world"
    And I press "SPC C-b"
    And I type "("
    Then I should not see "()"
    Given I add a local pair "\{/\}" on "python-mode" disabled only in string
    And I clear the buffer
    And I turn on python-mode
    And I turn on smartparens
    And I type "\{"
    Then I should see "\{\}"
    When I clear the buffer
    And I insert "'some text'"
    And I go to word "text"
    And I press "SPC C-b"
    And I type "\{"
    Then I should not see "\{\}"
    
  Scenario: Modify pair option of sub-group of modes previously added
    Given I add a local pair "*/*" on "rst-mode,python-mode"
    And I add a local pair "*/*" on "python-mode" enabled only in string
    And I turn on rst-mode
    And I turn on smartparens
    When I press "*"
    Then I should see "**"
    Given I switch to buffer "*new*"
    And I turn on python-mode
    And I turn on smartparens
    When I press "*"
    Then I should not see "**"
    When I insert "'This is some text'"
    And I go to word "some"
    And I press "SPC C-b"
    And I press "*"
    Then I should see "**"

