function trace(value, { kind, name }: ClassMethodDecoratorContext) {
	if (kind === 'method') {
		return function (...args) {
			console.log(`CALL ${name as string}: ${JSON.stringify(args)}`)
			const result = value.apply(this, args)
			console.log('=> ' + JSON.stringify(result))
			return result
		}
	}
}
