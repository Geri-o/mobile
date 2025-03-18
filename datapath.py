import re
import os
import uuid
import base64

class DataPath:
	def create_file(self, image):
		path = "static/image_files/{0}.png".format(uuid.uuid4().hex)
		with open(path, "wb") as file:
			image = re.sub("^data:image/.+;base64,", '', image)
			file.write(base64.b64decode(image.encode()))

		return path

	def remove_file(self, path):
		if os.path.exists(path):
			os.remove(path)
			return True
		else:
			return False