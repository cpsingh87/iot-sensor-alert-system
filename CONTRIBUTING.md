# Contributing to IoT Sensor Alert System

Thank you for your interest in contributing to the IoT Sensor Alert System! This document provides guidelines and information for contributors.

## 🤝 How to Contribute

### Reporting Issues
- Use GitHub Issues to report bugs or request features
- Provide detailed information including:
  - Steps to reproduce the issue
  - Expected vs actual behavior
  - Environment details (AWS region, versions, etc.)
  - Relevant logs or error messages

### Submitting Changes
1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/amazing-feature`)
3. **Make your changes** following the coding standards
4. **Test your changes** thoroughly
5. **Commit your changes** (`git commit -m 'Add amazing feature'`)
6. **Push to the branch** (`git push origin feature/amazing-feature`)
7. **Open a Pull Request**

## 🔧 Development Setup

### Prerequisites
- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Node.js >= 18.x
- Python 3.x

### Local Development
```bash
# Clone the repository
git clone https://github.com/yourusername/iot-sensor-alert-system.git
cd iot-sensor-alert-system

# Install dependencies
cd terraform
npm install

# Set up environment variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Testing
```bash
# Run system verification
./test_scripts/verify_system.ps1

# Run individual tests
./test_scripts/test_normal_reading.ps1
./test_scripts/test_high_temp_alert.ps1

# Test with sensor simulator
python sensor_simulator.py --topic-arn YOUR_TOPIC_ARN --count 5
```

## 📝 Coding Standards

### Terraform
- Use consistent naming conventions
- Include descriptions for all variables
- Add validation rules where appropriate
- Use tags for all resources

### JavaScript/Node.js
- Use ES6+ features
- Follow async/await patterns
- Include error handling
- Add comprehensive logging
- Use JSDoc comments for functions

### Python
- Follow PEP 8 style guide
- Use type hints where appropriate
- Include docstrings for functions
- Handle exceptions gracefully

### Documentation
- Update README.md for significant changes
- Add inline comments for complex logic
- Update architecture diagrams if needed
- Include examples in documentation

## 🧪 Testing Guidelines

### Unit Tests
- Write tests for new functionality
- Maintain test coverage above 80%
- Use descriptive test names
- Mock external dependencies

### Integration Tests
- Test end-to-end workflows
- Verify AWS service integrations
- Test error scenarios
- Validate alert functionality

### Performance Tests
- Test with realistic data volumes
- Monitor Lambda execution times
- Verify DynamoDB performance
- Test concurrent processing

## 🚀 Deployment Guidelines

### Infrastructure Changes
- Test in development environment first
- Use Terraform for all infrastructure changes
- Document any manual steps required
- Consider backward compatibility

### Lambda Function Updates
- Test locally when possible
- Verify package dependencies
- Check memory and timeout settings
- Monitor CloudWatch logs after deployment

### Database Schema Changes
- Plan migration strategy
- Consider data backup requirements
- Test with production-like data
- Document rollback procedures

## 📋 Pull Request Checklist

Before submitting a pull request, ensure:

- [ ] Code follows project coding standards
- [ ] All tests pass
- [ ] Documentation is updated
- [ ] Commit messages are descriptive
- [ ] No sensitive information is included
- [ ] Changes are backward compatible (or breaking changes are documented)
- [ ] Performance impact is considered
- [ ] Security implications are reviewed

## 🏷️ Commit Message Format

Use conventional commit format:
```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Test additions or modifications
- `chore`: Maintenance tasks

Examples:
```
feat(lambda): add batch processing for sensor data
fix(sns): resolve message delivery timeout issue
docs(readme): update deployment instructions
```

## 🔒 Security Guidelines

### Sensitive Information
- Never commit AWS credentials
- Use environment variables for configuration
- Encrypt sensitive data at rest
- Follow least privilege principle

### Code Security
- Validate all inputs
- Use parameterized queries
- Implement proper error handling
- Regular dependency updates

### Infrastructure Security
- Use IAM roles instead of users
- Enable encryption for all services
- Implement network security controls
- Regular security audits

## 📚 Resources

### AWS Documentation
- [AWS Lambda Developer Guide](https://docs.aws.amazon.com/lambda/)
- [Amazon SNS Developer Guide](https://docs.aws.amazon.com/sns/)
- [Amazon DynamoDB Developer Guide](https://docs.aws.amazon.com/dynamodb/)
- [Amazon SES Developer Guide](https://docs.aws.amazon.com/ses/)

### Terraform
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

### Node.js
- [AWS SDK for JavaScript v3](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## 🎯 Areas for Contribution

We welcome contributions in these areas:

### Features
- Real-time dashboard for sensor data
- Machine learning for anomaly detection
- Multi-tenant support
- Additional sensor types
- Mobile app integration

### Improvements
- Performance optimizations
- Cost reduction strategies
- Enhanced monitoring
- Better error handling
- Documentation improvements

### Testing
- Additional test scenarios
- Load testing framework
- Automated testing pipeline
- Security testing

### Documentation
- Tutorial videos
- Architecture diagrams
- Best practices guide
- Troubleshooting scenarios

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes for significant contributions
- GitHub contributor statistics

## 📞 Getting Help

If you need help with contributing:
- Check existing GitHub Issues
- Review documentation
- Ask questions in GitHub Discussions
- Contact maintainers directly

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to the IoT Sensor Alert System! 🚀