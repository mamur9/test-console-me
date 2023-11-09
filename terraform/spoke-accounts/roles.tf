# data "aws_iam_policy_document" "consoleme_user_deny_all" {
#   statement {
#     sid       = "ConsoleMeWillAssumeThis"
#     effect    = "Deny"
#     resources = ["*"]
#     actions = [
#       "*"
#     ]
#   }
# }

data "aws_iam_policy_document" "consoleme_user_allow_all" {
  statement {
    sid       = "ConsoleMeWillAssumeThis"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "*"
    ]
  }
}




# resource "aws_iam_role_policy" "consoleme_admin_role_policy_deny_all" {
#   name   = "ConsoleMeAdminPolicyDenayAll"
#   role   = aws_iam_role.consoleme_admin_role.id
#   policy = data.aws_iam_policy_document.consoleme_user_deny_all.json
# }

resource "aws_iam_role_policy" "consoleme_admin_role_policy_allow_all" {
  name   = "ConsoleMeAdminPolicyAllowAll"
  role   = aws_iam_role.consoleme_admin_role.id
  policy = data.aws_iam_policy_document.consoleme_user_allow_all.json
}

# resource "aws_iam_role_policy" "consoleme_developer_role_policy" {
#   name   = "ConsoleMeDeveloperPolicy"
#   role   = aws_iam_role.consoleme_developer_role.id
#   policy = data.aws_iam_policy_document.consoleme_user_deny_all.json
# }


resource "aws_iam_role" "consoleme_admin_role" {
  name               = "ConsoleMeAdminRole"
  assume_role_policy = data.aws_iam_policy_document.consoleme_target_trust_policy.json
}

resource "aws_iam_role" "consoleme_developer_role" {
  name               = "ConsoleMeDeveloperRole"
  assume_role_policy = data.aws_iam_policy_document.consoleme_target_trust_policy.json
}
