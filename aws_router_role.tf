resource "aws_iam_role" "rtb_updater_iam_role" {
    name = "rtb_updater"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "allow_rtb_update_iam_policy" {
    name = "allow_rtb_update"
    description = "Allow updating a route table"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:ReplaceRoute",
        "ec2:ModifyInstanceAttribute"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeRouteTables",
        "ec2:DescribeInstances"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "rtb_updater_allow_rtb_update" {
    name = "rtb_updater_allow_rtb_update"
    policy_arn = "${aws_iam_policy.allow_rtb_update_iam_policy.arn}"
    roles = [
        "${aws_iam_role.rtb_updater_iam_role.name}"
    ]
}

resource "aws_iam_instance_profile" "rtb_updater_iam_instance_profile" {
    name = "rtb_updater"
    roles = [
        "${aws_iam_role.rtb_updater_iam_role.name}"
    ]
}
