class HTTPError extends Error {
	constructor(public response: Response) {
		super()
	}

	get message() {
		return `HTTP ${this.response.status}: ${this.response.statusText}`
	}
}

export async function postJSON(url: string, json: any, opts: RequestInit = {}): Promise<Response> {
	const res = await fetch(url, { ...opts, method: 'POST', body: JSON.stringify(json) })
	if (res.ok) return res
	else throw new HTTPError(res)
}
